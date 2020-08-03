class Business::RoomsController < BusinessController
  before_action :load_room, only: :show
  before_action :load_room_pagination, only: :index

  def index
    @countries = Country.pluck :name, :id
    if params[:filter_country].present?
      @country = Country.find_by id: params[:filter_country]
      if @country.nil?
        @locations = Location.pluck :name, :id
      end
      @locations = @country.locations.pluck :name, :id
    end
    filter
  end

  def show
    @reports = @room.reports.page(params[:page]).per Settings.pagination_commit
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
                  .by_location(params[:filter_location])
                  .by_country(params[:filter_country])
                  .page(params[:page]).per Settings.pagination
  end
end
