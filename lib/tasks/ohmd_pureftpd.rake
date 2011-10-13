# Ohm PureFTPd daemon
require 'active_record'

class PureftpdMigrations < ActiveRecord::Migration
  def self.up
    create_table :pureftpd_users do |t|
      t.integer :user_id
      t.integer :max_accounts

      t.timestamps
    end
    create_table :pureftpd_accounts do |t|
      t.string :username
      t.string :password
      t.integer :pureftpd_user_id
      t.string :root
      t.integer :domain_id

      t.timestamps
    end
    LogFile.create :name => "FTP transfers", :path => "/var/log/pure-ftpd/transfer.log"
  end

  def self.down
    drop_table :pureftpd_users
    drop_table :pureftpd_accounts
    LogFile.find_by_name("FTP transfers").destroy
  end
end

def makeroot root, username, start
  unless root.empty?
    current = "#{start}/#{root.first}"
    root.delete_at 0
    unless File.directory? current
      Dir.mkdir current
      system "chown #{username}:#{username} \"#{current}\""
      system "chmod ug+rwx,o-rwx \"#{current}\""
    end
    makeroot root, username, current
  end
end

namespace :ohmd do
  namespace :pureftpd do
    task :run => :environment do
      def ubuntu1004
        # Check for orphan users and accounts first
        PureftpdUser.all.select { |u| u.user.nil? }.each do |orphan|
          orphan.destroy
        end
        PureftpdAccount.all.select { |a| a.domain.nil? }.each do |orphan|
          orphan.destroy
        end

        # passwd format: FTP_USERNAME:FTP_PASSWORD:REAL_UID:REAL_GID::FTP_ROOT/./::::::::::::
        # "/./" forces chrooting in the FTP_ROOT to limit user's access to the filesystem
        # http://download.pureftpd.org/pub/pure-ftpd/doc/README.Virtual-Users
        newpasswd = ""

        PureftpdUser.all.each do |u|
          # Extract UID and GID
          username = u.user.username
          userinfo = File.read("/etc/passwd").split("\n").select { |p| p.split(":")[0] == username }
          uid = userinfo[0].split(":")[2]
          gid = userinfo[0].split(":")[3]

          # Add a default account for user
          newpasswd << "#{username}:#{u.user.ohmd_password.split("\\$").join("$")}:#{uid}:#{gid}::/home/#{username}/./::::::::::::\n"

          # Add one line per account
          u.pureftpd_accounts.each do |a|
            newpasswd << "#{a.full_username}:#{a.password.split("\\$").join("$")}:#{uid}:#{gid}::/home/#{username}/#{a.root}/./::::::::::::\n"
            # Make sure root exists
            makeroot a.root.split('/'), username, "/home/#{username}"
          end
        end
        File.open("/etc/pure-ftpd/pureftpd.passwd", "w") { |f| f.puts newpasswd }

        # Add DNS entries
        PureftpdAccount.all.collect { |a| a.domain }.uniq.each do |dom|
          unless dom.dns_entries.select { |e| e.creator=="pureftpd" }.count > 0
            ["ftp"].each do |sub|
              DnsEntry.new(:line => "#{sub}\tIN\tA",
                           :add_ip => true,
                           :creator => "pureftpd",
                           :domain_id => dom.id).save
            end
          end
        end

        # Generate PureDB
        system "pure-pw mkdb"
      end # ubuntu1004

      alias default ubuntu1004
      begin
        send Configuration.first.os
      rescue NameError, TypeError
        default
      end
    end # run

    task :install => :environment do
      def ubuntu1004
        # Install Pure-FTPd
        system "apt-get install -y pure-ftpd" \
          or raise "Error running apt-get"

        # Disable PAM authentication
        File.open("/etc/pure-ftpd/conf/PAMAuthentication", "w") { |f| f.puts "no" }

        # Enable PureDB auth (virtual users)
        system "ln -fs ../conf/PureDB /etc/pure-ftpd/auth/75pdb" \
          or raise "Failed to create link to PureDB"

        # Generate initial PureDB, or else server refuses to start
        File.open("/etc/pure-ftpd/pureftpd.passwd", "w") { |f| f.puts "" }
        system "pure-pw mkdb" \
          or raise "Error building PureDB"

        # Restart FTP server
        system "service pure-ftpd restart" \
          or raise "Failed to restart PureFTPd service"
      end # ubuntu1004

      alias default ubuntu1004
      begin
        send Configuration.first.os
      rescue NameError, TypeError
        default
      end
    end # install

    task :remove => :environment do
      def ubuntu1004
        # Remove Pure-FTPd
        system "apt-get remove -y pure-ftpd"
      end # ubuntu1004

      alias default ubuntu1004
      begin
        send Configuration.first.os
      rescue NameError, TypeError
        default
      end
    end # remove

    task :db_up => :environment do
      PureftpdMigrations.up
    end

    task :db_down => :environment do
      PureftpdMigrations.down
    end
  end
end