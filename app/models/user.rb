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
    :foreign_key => :twitter_followee_id,
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
    :foreign_key => :twitter_follower_id,
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

  def self.fetch_by_ids(ids)
    existing_users = User.where("twitter_user_id IN (?)", ids)
    existing_ids = existing_users.map(&:twitter_user_id)

    new_ids = ids.reject { |id| existing_ids.include?(id) }

    # twitter won't let you look up >100 users at a time; we would probably
    # want to make multiple queries, but I'm lazy.
    new_users_params = []
    raise "hell" if new_ids.length > 100

    unless new_ids.empty?
      new_users_params = TwitterSession.post(
        "users/lookup",
        :user_id => new_ids.join(",")
      )
    end

    new_users = new_users_params.map do |new_user_params|
      User.parse_twitter_user(new_user_params)
    end

    existing_users + new_users
  end

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

  def fetch_followers
    follower_ids = TwitterSession.get(
      "followers/ids",
      { :user_id => self.twitter_user_id, :stringify_ids => true }
    )["ids"]

    User.fetch_by_ids(follower_ids)
  end

  def sync_followers
    fetched_followers = self.fetch_followers
    fetched_followers.each do |fetched_follower|
      fetched_follower.save! unless fetched_follower.persisted?
    end

    self.followers = fetched_followers

    nil
  end

  def sync_statuses
    statuses = Status.fetch_statuses_for_user(self)
    statuses.each { |status| status.save! unless status.persisted? }

    nil
  end
end
