require 'twitter_session'

class User < ActiveRecord::Base
  attr_accessible(
    :twitter_user_id,
    :screen_name
  )

  has_many(
    :statuses,
    :foreign_key => :twitter_user_id,
    :primary_key => :twitter_user_id
  )

  has_many(
    :inbound_follows,
    :class_name => "Follow",
    :foreign_key => :followee_user_id,
    :primary_key => :twitter_user_id
  )

  has_many(
    :followers,
    :class_name => "User",
    :through => :inbound_follows,
    :source => :follower
  )

  has_many(
    :outbound_follows,
    :class_name => "Follow",
    :foreign_key => :follower_user_id,
    :primary_key => :twitter_user_id
  )

  has_many(
    :followed_users,
    :class_name => "User",
    :through => :outbound_follows,
    :source => :followee
  )

  validates(
    :twitter_user_id,
    :username,
    :presence => true
  )

  def self.parse_twitter_user(twitter_user_params)
    User.new(
      :screen_name => twitter_user_params["screen_name"],
      :twitter_user_id => twitter_user_params["id_str"]
    )
  end
end
