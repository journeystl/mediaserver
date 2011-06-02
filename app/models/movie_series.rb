class MovieSeries
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::MultiParameterAttributes
  has_attached_file :thumbpic,
    :styles => { :thumb => "60x60" },
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/amazon_s3.yml",
    :path           => ':attachment/:id/:style.:extension',
    :default_url => '/mediaManager/images/missing.gif',
    :bucket => 'movie_series_pics'
  field :name, :type => String
  field :tagline, :type => String
  field :category, :type => String
  field :startDate, :type => Date

  references_many :movies

  def parentmovies
    return self.movies.where(:parent=>-1).order_by(:date.desc)
  end

end
