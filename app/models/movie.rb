class Movie
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Timestamps


  has_attached_file :thumbpic, 
    :styles => { :thumb => "60x60" },
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/amazon_s3.yml",
    :path           => ':attachment/:id/:style.:extension',
    :bucket => 'movie_pics'

  field :title, :type => String
  field :date, :type => Date
  field :speaker, :type => String
  field :bookofbible, :type => String
  field :scriptureref, :type => String
  field :summary, :type => String
  field :speaker, :type => String
  field :duration, :type => String
  field :category, :type => String
  field :parent, :type => Integer
  field :process_venue, :type => Boolean
  field :process_mobile, :type => Boolean
  field :process_website, :type => Boolean
  field :process_mp3, :type => Boolean
  field :process_proof, :type => Boolean
  field :process_youtube, :type => Boolean
  field :status, :type => String
  field :moviefile, :type => String
  field :filesize, :type => Integer
  field :notchanged, :type => Boolean, :default => false

  referenced_in :movie_series

  def realparent 
    if self.parent != -1 and self.parent != nil
      @a = Movie.find(self.parent)
      return @a.title
    end
    return "None"
  end

  def self.selectcollection
    @a = Movie.all 
    @b = Hash.new
    @b["None"] = "-1"
    @a.each do |c|
      @b[c.date.to_s + " - " + c.title] = c.id unless (c.parent != -1)
    end

    return @b
  end

  def children
    Movie.all(:conditions => {'parent' => self.id.to_s})
  end

  def self.standalone
    Movie.all(:conditions => {'parent' => -1, 'movie_series_id' => nil})
  end
end
