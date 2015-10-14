class V1::ParticipationsController < V1::AppController

  before_action :forbidden_for_guest, only: :create

  def create
    @participation = Participation.new(participation_params) do |p|
      p.user = current_user
    end
    if @participation.save
      head :created
    else
      render json: @participation.errors, status: :unprocessable_entity
    end
  end

  private

    def participation_params
      begin
        params.require(:participation).permit(:event_id)
      rescue
        {}
      end
    end
end
