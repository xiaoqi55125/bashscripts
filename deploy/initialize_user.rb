#! /usr/bin/env ruby

require 'mysql2'

MYSQL_SERVER='172.16.206.16'
MYSQL_ACCOUNT='root'
MYSQL_PASSWORD='123456'
MYSQL_DATABASE='microblog'
MYSQL_ENCODING='utf8'

puts "connecting..."

begin
	client = Mysql2::Client.new(:host=>MYSQL_SERVER,
                            :username=>MYSQL_ACCOUNT,
                            :password=>MYSQL_PASSWORD,
                            :database=>MYSQL_DATABASE,
                            :encoding=>MYSQL_ENCODING)

	# users = client.query("select user_id from user")

	# users.each do |row|
	# 	user_id = row['user_id']
	# 	puts "updating #{user_id}..."

	# 	following_count = client.query("select count(1) follow_count from user_following where user_id='#{user_id}'")
	# 							.first['follow_count']
	# 	fans_count = client.query("select count(1) fans_count from user_follower where user_id='#{user_id}'")
	# 						.first['fans_count']
	# 	blog_count = client.query("select count(1) blog_count from message where creator_id='#{user_id}'")
	# 						.first['blog_count']

	# 	next if(following_count==0 && fans_count==0 && blog_count==0) 
	# 	#puts "#{following_count}:#{fans_count}:#{blog_count}"
	# 	client.query("update user set msg_count=#{blog_count},fans_count=#{fans_count},following_count=#{following_count} where user_id=#{user_id}")

	# end
	
	puts "updating following_count"

	following_users = client.query("select count(1) following_count,user_id from user_following group by user_id")
	following_users.each do |row|
		user_id = row['user_id']
		following_count = row['following_count']

		client.query("update user set following_count=#{following_count} where user_id='#{user_id}'")
	end

	puts "updating fans_count"

	fans = client.query("select count(1) fans_count,user_id from user_follower group by user_id")
	fans.each do |row|
		user_id = row['user_id']
		fans_count = row['fans_count']

		client.query("update user set fans_count=#{fans_count} where user_id='#{user_id}'")
	end

	puts "updating blog_count"

	blog_user = client.query("select count(1) blog_count,creator_id from message group by creator_id")
	blog_user.each do |row|
		user_id = row['creator_id']
		blog_count = row['blog_count']

		client.query("update user set msg_count=#{blog_count} where user_id='#{user_id}'")
	end


	puts "updating forward_count"

	forwarded_feeds = client.query("SELECT count(1) forward_count, referenced_msg_id FROM msg_ref_msg group by referenced_msg_id")

	forwarded_feeds.each do |row|
		feed_id = row['referenced_msg_id']
		forward_count = row['forward_count']

		client.query("update message set reforwarded_count=#{forward_count} where msg_id='#{feed_id}'")
	end

	puts "updating comment_count"

	comments = client.query("SELECT count(1) comment_count,msg_id FROM microblog.comment  group by msg_id")

	comments.each do |row|
		feed_id = row['msg_id']
		comment_count = row['comment_count']

		client.query("update message set commented_count=#{comment_count} where msg_id='#{feed_id}'")
	end


	puts 'done'


rescue Exception => e
	puts "error: #{e.inspect}"
end




