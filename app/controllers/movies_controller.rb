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
    filters = {'G' => '0',
               'PG' => '0',
               'PG-13' => '0',
               'R' => '0',
               'NC-17' => '0'}
    if params[:commit] == nil
      if session[:Filters] == nil
      else
        filters = session[:Filters]
      end
    else
      if params[:ratings] == nil 
      else                           
        params[:ratings].each_key do |key|
          filters[key] = '1'
        end
      end
      session[:Filters] = filters
    end
    
    #  It seems stupid, but let's be Restful
    if (params[:SortOrder] == nil) && (sortorder != nil)
      redirect_parameters = "?SortOrder=" + sortorder
      redirect_to movies_path + redirect_parameters
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
