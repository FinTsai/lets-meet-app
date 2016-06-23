class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :get_geo_location, :search_nearby, only: [:new, :edit]

  # GET /events
  # GET /events.json
  def index
    @events = Event.all
  end

  # GET /events/1
  # GET /events/1.json
  def show
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params)
    @event.user_id = current_user.id
    @event.location_name = retrieve_location_name(@event.location_place_id)
    saved_event = @event.save

    guest_id_params.each do |guest_id|
      @event.invitations.create(guest_id: guest_id, is_going: false)
    end

    respond_to do |format|
      if saved_event
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:user_id, :location_place_id, :start_date_time, :end_date_time, :message)
    end

    def guest_id_params
      params.require(:guest_ids)
    end

    def search_nearby
      @nearby_users = User.all
      if @user.latitude && @user.longitude
        @client = GooglePlaces::Client.new(ENV["GOOGLE_PLACES_API_KEY"])
        @locations = @client.spots(@user.latitude, @user.longitude, :types => 'cafe', :radius => 300)
      else
        @locations = []
      end
    end

    def retrieve_location_name(location_place_id)
      @client = GooglePlaces::Client.new(ENV["GOOGLE_PLACES_API_KEY"])
      location = @client.spot(location_place_id)
      return location.name
    end
end
