class Business::RoomsController < BusinessController
  before_action :load_room, only: :show
  before_action :load_room_pagination, only: :index
  before_action :logged_in_user

  def index
    @countries = Country.pluck :name, :id
    if params[:filter_country].present?
      @country = Country.find_by id: params[:filter_country]
      @locations = Location.pluck :name, :id unless @country

      @locations = @country.locations.pluck :name, :id
    end
    filter
  end

  def show
    @reports = @room.reports.page(params[:page]).per Settings.pagination_commit
    @event_load = Event.where room_id: params[:id]
    @monday = DateTime.now -DateTime.now.cwday + 1
  end

  private

  def load_room
    @room = Room.find_by id: params[:id]
    return if @room

    render :index
    flash.now[:danger] = t "business.room.error_load_room"
  end

  def filter
    @rooms = Room.by_name(params[:search_name])
                 .by_country(params[:filter_country])
                 .by_location(params[:filter_location])
                 .page(params[:page]).per Settings.pagination
  end
end
