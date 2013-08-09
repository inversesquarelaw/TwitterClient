require 'twitter_session'

class Status < ActiveRecord::Base
  attr_accessible(
    :body,
    :twitter_status_id,
    :twitter_user_id
  )

  belongs_to(
    :user,
    :foreign_key => :twitter_user_id,
    :primary_key => :twitter_user_id
  )

  validates(
    :body,
    :twitter_status_id,
    :twitter_user_id,
    :presence => true
  )

  def self.fetch_statuses_for_user(user)
    statuses_params = TwitterSession.get(
      "statuses/user_timeline",
      { :user_id => user.twitter_user_id }
    )
    statuses_ids = statuses_params.map do |status_params|
      status_params["id_str"]
    end

    old_statuses = Status.where(
      "twitter_status_id IN (?)",
      statuses_ids
    )
    old_statuses_ids = old_statuses.map(&:twitter_status_id)

    new_statuses_params = statuses_params.reject do |status_params|
      old_statuses_ids.include?(status_params["id_str"])
    end
    new_statuses = new_statuses_params.map do |status_params|
      Status.parse_twitter_status(status_params)
    end

    old_statuses + new_statuses
  end


  def self.parse_twitter_status(twitter_status_params)
    Status.new(
      :body => twitter_status_params["text"],
      :twitter_status_id => twitter_status_params["id_str"],
      :twitter_user_id => twitter_status_params["user"]["id_str"]
    )
  end

  def self.post(body)
    status_params = TwitterSession.post(
      "statuses/update",
      { :status => body }
    )

    Status.parse_twitter_status(status_params).save!
  end
end
