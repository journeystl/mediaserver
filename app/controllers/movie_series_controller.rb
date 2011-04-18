class MovieSeriesController < ApplicationController
  before_filter :authenticate_user!, :except => [:json_sermon_series]

  def json_sermon_series
    @series = MovieSeries.all(:conditions => {:category => "Sermon"}).order_by(:startDate.desc).entries
    for a in @series
      a["allmovies"] = a.movies.excludes(:url_website => nil).order_by(:date.desc).entries
      a["id"] = a.id
      if a.thumbpic?
        a["thumbpic_url"] = a.thumbpic.url
      else 
        a["thumbpic_url"] = ""
      end
      for movie in a["allmovies"]
        if movie.thumbpic?
          movie["thumbpic_url"] = movie.thumbpic.url
        else
          movie["thumbpic_url"] = ""
        end
        movie["id"] = movie.id
        if movie.parent == -1
          movie.parent = ""
        end
      end
    end
    render :json => @series
  end

  # GET /movie_series
  # GET /movie_series.xml
  def index
    @movie_series = MovieSeries.order_by(:startDate.desc).entries
    for a in @movie_series
      a["allmovies"] = a.movies.where(:parent=>-1).excludes(:url_website => nil).order_by(:date.desc).entries
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @movie_series }
    end
  end

  # GET /movie_series/1
  # GET /movie_series/1.xml
  def show
    @movie_series = MovieSeries.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @movie_series }
    end
  end

  # GET /movie_series/new
  # GET /movie_series/new.xml
  def new
    @movie_series = MovieSeries.new(:startDate => Date.today)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @movie_series }
    end
  end

  # GET /movie_series/1/edit
  def edit
    @movie_series = MovieSeries.find(params[:id])
  end

  # POST /movie_series
  # POST /movie_series.xml
  def create
    @movie_series = MovieSeries.new(params[:movie_series])

    respond_to do |format|
      if @movie_series.save
        format.html { redirect_to(movie_series_index_url, :notice => 'Movie series was successfully created.') }
        format.xml  { render :xml => @movie_series, :status => :created, :location => @movie_series }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @movie_series.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /movie_series/1
  # PUT /movie_series/1.xml
  def update
    @movie_series = MovieSeries.find(params[:id])

    respond_to do |format|
      if @movie_series.update_attributes(params[:movie_series])
        format.html { redirect_to(movie_series_index_url, :notice => 'Movie series was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @movie_series.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /movie_series/1
  # DELETE /movie_series/1.xml
  def destroy
    @movie_series = MovieSeries.find(params[:id])
    @movie_series.destroy

    respond_to do |format|
      format.html { redirect_to(movie_series_index_url) }
      format.xml  { head :ok }
    end
  end
end
