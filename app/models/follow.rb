class Follow < ActiveRecord::Base
  attr_accessible(
    :twitter_followee_id,
    :twitter_follower_id
  )

  belongs_to(
    :followee,
    :foreign_key => :twitter_user_id,
    :primary_key => :twitter_user_id
  )

  belongs_to(
    :follower,
    :foreign_key => :twitter_user_id,
    :primary_key => :twitter_user_id
  )

  validates(
    :twitter_followee_id,
    :twitter_follower_id,
    :presence => true
  )
end
