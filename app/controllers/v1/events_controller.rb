class V1::EventsController < V1::AppController

  before_action :set_event, only: [ :show, :update, :destroy ]
  before_action :forbidden_for_guest, except: [ :index, :show ]
  before_action :allowed_to_creator, only: [ :update, :destroy ]

  setter_for :event

  def index
    @events = Event.upcoming
    render json: @events, each_serializer: V1::EventSerializer, status: :ok
  end

  def show
    render json: @event, serializer: V1::EventSerializer, status: :ok
  end

  def create
    @event = Event.new(event_params)
    @event.creator = current_user
    if @event.save
      render json: @event, status: :created
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  def update
    if @event.update(event_params)
      render json: @event, status: :ok
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    head :no_content
  end

  private

    def allowed_to_creator
      render json: { error: "must be event's creator" }, status: :unauthorized unless @event.creator == current_user
    end

    def event_params
      begin
        params.require(:event).permit(:title, :description, :start_latitude, :start_longitude, :start_time, :type)
      rescue
        {}
      end
    end

    def default_serializer_options
      { root: false }
    end
end
