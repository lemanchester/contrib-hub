class User < ActiveRecord::Base
  extend FriendlyId
  include UserPresenter

  attr_accessible :github_id, :name, :token, :location, :latitude, :longitude, :email,
    :avatar_url, :github_url, :public_repos, :public_gists, :followers, :following

  ## friendly url
  friendly_id :github_id, use: :slugged

  ## relations
  has_many :repos
  has_many :helped_repos

  ## geolocation
  geocoded_by :location
  after_validation :geocode, :if => :location_changed?

  ## validations
  validates :github_id, :token, :presence => true
  validates :github_id, :uniqueness => true

  ## instance methods

  def update_repo_status(repo)
    if repo.is_being_helped_by?(self)
      HelpedRepo.find_by_user_id_and_repo_id(self.id, repo.id).destroy
    else
      HelpedRepo.create!(user_id: self.id, repo_id: repo.id, really_helping: false)
    end
  end

  ## class methods

  class << self

    def find_or_create_from(auth_data)
      user_data = {
        github_id:    auth_data["info"]["nickname"],
        token:        auth_data["credentials"]["token"],
        name:         auth_data["info"]["name"],
        email:        auth_data["info"]["email"],
        location:     auth_data["extra"]["raw_info"]["location"],
        avatar_url:   auth_data["extra"]["raw_info"]["avatar_url"],
        github_url:   auth_data["extra"]["raw_info"]["html_url"],
        public_repos: auth_data["extra"]["raw_info"]["public_repos"],
        public_gists: auth_data["extra"]["raw_info"]["public_gists"],
        followers:    auth_data["extra"]["raw_info"]["followers"],
        following:    auth_data["extra"]["raw_info"]["following"]
      }

      user = find_by_github_id(user_data[:github_id])

      if user
        user.update_attributes(user_data)
      else
        user = User.create!(user_data)
      end
      user
    end

  end
end
