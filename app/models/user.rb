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
    :screen_name,
    :presence => true
  )

  def self.fetch_by_screen_name(screen_name)
    params = TwitterSession.get(
      "users/show",
      { :screen_name => screen_name }
    )

    self.parse_twitter_user(params)
  end

  def self.parse_twitter_user(twitter_user_params)
    User.new(
      :screen_name => twitter_user_params["screen_name"],
      :twitter_user_id => twitter_user_params["id_str"]
    )
  end

  def fetch_statuses
    params = TwitterSession.get(
      "statuses/user_timeline",
      { :user_id => twitter_user_id }
    )

    params.map do |twitter_status_params|
      Status.parse_twitter_status(twitter_status_params)
    end
  end

  def sync_statuses
    old_status_ids = self.statuses.pluck("twitter_status_id")

    new_statuses = self.fetch_statuses
    new_statuses.reject! do |new_status|
      old_status_ids.include?(new_status.twitter_status_id)
    end

    new_statuses.each { |new_status| new_status.save! }
  end
end
