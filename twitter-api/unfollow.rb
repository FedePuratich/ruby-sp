require 'jumpstart_auth'

class TwitterClient
  attr_reader :client

  def initialize
	@client = JumpstartAuth.twitter
  end

  def followers_list
	followers = @client.follower_ids
	begin
	  followers.to_a
	rescue Twitter::Error::TooManyRequests => error
	  sleep error.rate_limit.reset_in + 1
	  retry
	end
	return followers
  end

  def following_list
	friends = @client.friend_ids
	begin
	  friends.to_a
	rescue Twitter::Error::TooManyRequests => error
	  sleep error.rate_limit.reset_in + 1
	  retry
	end
	return friends
  end

  def no_friendship(followers, friends)
	to_remove = friends.select { |friend| !followers.include?(friend) }
  end

  def unfollow_friends(friends)
	friends.each do |friend|
	  @client.unfollow(friend)
	end
	puts "Done"
  end

  def print_s(user)
	puts "#{@client.user(user).screen_name} does not follow you..."
  end
end

user = TwitterClient.new
no_friendship = user.no_friendship(user.followers_list, user.following_list)

puts "There are #{no_friendship.length} friends that don't follow you back."
print "Unfollow friends?(y/n): " if no_friendship.length > 0
answer = gets.chomp
user.unfollow_friends(no_friendship) if answer.downcase == 'y'
puts "Bye"
