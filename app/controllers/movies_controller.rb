class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
  
    # Construct view attributes from session hash
    if params[:SortOrder] == nil 
      sortorder = session[:SortOrder]
    else 
      sortorder = params[:SortOrder]
      session[:SortOrder] = sortorder
    end
  
    #  construct the filter hash for the view  
    filters = Hash.new
    if params[:commit] == nil
      if session[:Filters] == nil
        Movie.group('rating').each do |m|
          filters[m.rating] = '0' 
        end
      else
        filters = session[:Filters]
      end
    else
      if params[:ratings] == nil     # if no boxes are checked, select all
        Movie.group('rating').each do |m|
          filters[m.rating] = '0'
        end
      else                           # if some boxes are checked, select only checked boxes
        Movie.group('rating').each do |m|
          filters[m.rating] = '0' 
        end
        params[:ratings].each_key do |key|
          filters[key] = '1'
        end
      end
      session[:Filters] = filters
    end
             
    #  Based upon sortorder, highlight the header
    if sortorder == 'title'
      @title_hilite = :hilite
      @release_date_hilite = :no_hilite
    elsif sortorder == 'release_date'
      @title_hilite = :no_hilite
      @release_date_hilite = :hilite
    else
      @title_hilite = :no_hilite
      @release_date_hilite = :no_hilite
    end
    
    #  Based upon filter, set the state of checkboxes
    @all_ratings = filters
    
    #  Based upon sortorder and filters, select movies to display
    whereclause = Array.new
    filters.each do |k, v|
      if v == '1'
        whereclause << k
      end
    end

    #@movies = Movie.order(sortorder).where(:rating => whereclause).all
    @movies = Movie.order(sortorder).find(:all, :conditions => { :rating => whereclause })
 

  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
