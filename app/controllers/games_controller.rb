class GamesController < ApplicationController

  get '/games' do
    @current_user = current_user
    @users = User.all
    @archived_games = ArchivedGame.all
    erb :"games/list_games"
  end

  get '/games/new' do
    puts Genre.all
    @current_user = verify_user
    @platforms = Platform.all
    @genres = Genre.all
    erb :"games/add_game"
  end

  get '/games/:slug' do
    @archived_game = ArchivedGame.find_by_slug(params[:slug])
    @users = User.all
    erb :"games/show_by_slug"
  end

  get '/games/:slug/edit' do
    @game = Game.find_by_slug(params[:slug])
    @platforms = Platform.all
    @genres = Genre.all
    erb :"games/edit_game"
  end
  # get '/game/:id' do
  #   @current_user = current_user
  #   erb :"games/show_by_id"
  # end

  # get '/games/:id/edit' do
  #   @current_user = verify_user
  # end

  post '/games' do
    puts Genre.all
    @user = User.find(session[:user_id])
    if params[:title] == ""
      flash[:message] = "You must enter a title for the game you'd like to add to your Journal. Please try again."
      redirect to '/games/new'
    elsif params[:game][:platform_id].nil? || params[:platform] != ""
      flash[:message] = "You must either select a platform or create a new one, and can only associate one platform with the created game."
      redirect to '/games/new'
    elsif params[:game][:genre_id].nil? || params[:genre] != ""
      flash[:message] = "You must either select a genre or create a new one, and can only associate one genre with the created game."
      redirect to '/games/new'
    end

    @owned_game = OwnedGame.create(title: params[:title])
    @archived_game = ArchivedGame.find_or_create_by(title: params[:title])

    if params[:game][:platform_id] != nil
      @platform = Platform.find(params[:game][:platform_id])
    elsif params[:platform] != ""
      @platform = Platform.find_or_create_by(name: params[:platform])
    elsif params[:game][:genre_id] != nil
      @genre = Genre.find(params[:game][:genre_id])
    elsif params[:genre] != ""
      @genre = Genre.find_or_create_by(name: params[:genre])
    end

    @owned_game.platform_id = @platform.id
    @owned_game.genre_id = @genre.id
    @owned_game.notes = params[:notes]
    @owned_game.save

    @archived_game.platform_ids << @platform.id if !(@archived_game.platform_ids.include?(@platform.id))
    @archived_game.genre_id = @genre.id if !(@archived_game.genre_id == @genre.id)
    @archived_game.save


    @user.owned_games << @owned_game
    # @user.owned_games << @owned_game if !@user.owned_games.include?(@owned_game)

    redirect to "/users/#{@user.slug}"
  end

  patch '/games/:slug' do

  end

  delete '/games/:slug/delete' do

  end

end
