class MovieSeries
  include Mongoid::Document
  include Mongoid::Paperclip
  has_attached_file :thumbpic,
    :styles => { :thumb => "60x60" },
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/amazon_s3.yml",
    :path           => ':attachment/:id/:style.:extension',
    :bucket => 'movie_series_pics'
  field :name, :type => String
  field :tagline, :type => String
  field :category, :type => String
  field :startDate, :type => Date

  references_many :movies

  def parentmovies
    a = self.movies
    b = Array.new

    a.each do |c|
      b << c unless (c.parent != -1)
    end

    return b
  end

end
