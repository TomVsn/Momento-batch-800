class TripsController < ApplicationController
  # def index
  # end

  def index
    # @trips = Trip.all
    @user = current_user
    @trip = Trip.new
    @users = User.all
    @participant = Participant.new
    @trips = policy_scope(Trip)
    @coming_trips = @trips.select {|trip| trip.start_date > Time.now}
    @past_trips = @trips.select {|trip| trip.start_date < Time.now}
  end

  def show
    @trip = Trip.find(params[:id])
    # Info to display all transportations related to this trip
    @transportations = @trip.transportations
    # Info to display all messages related to this trip
    @messages = @trip.messages
    # Info to display all events related to this trip
    @events = @trip.events
    # Info for creating new participant
    @users = User.all
    @new_participant = Participant.new

    # @event_id = Event.find(params[:id])
    @event_participant = EventParticipant.new
    @event = Event.new
    @participants = @trip.participants
    @participant = @participants.find_by(user: current_user)
    @accomodations = @trip.accomodations
    @new_accomodation = Accomodation.new
    @new_expense = Expense.new
    if @participant != nil
      @sum_of_mutual_expenses = Expense.includes(participant: :trip)
                                .references(:trip)
                                .where(trips: { id: @participant.trip }, mutual: true).sum(:amount)
      @non_mutual_expenses = Expense.where(participant: @participant, mutual: false).references(:trip).sum(:amount)
      @details_expenses = Expense.includes(participant: :trip)
                        .references(:trip)
                        .where(trips: { id: @participant.trip })

      @participants_expenses = Participant.where(trip: @participant.trip)
      @total_per_participant = ((@sum_of_mutual_expenses / @participants_expenses.count) + @non_mutual_expenses).round(2)
      @my_expenses = {mutual: @sum_of_mutual_expenses / @participants_expenses.count, individual: @non_mutual_expenses}
    end
    # first_step = @trip.participants.map { |participant| participant.transportations}
    # @transportations = first_step.flatten
    @new_transportation = Transportation.new
    @new_accomodation_vote = AccomodationVote.new
    @new_message = Message.new
    @markers = @accomodations.geocoded.map do |accomodation|
      {
        lat: accomodation.latitude,
        lng: accomodation.longitude,
        info_window: render_to_string(partial: "info_window", locals: { accomodations: accomodation }),
        image_url: helpers.asset_url("emplacement.png")
      }
    end
    authorize @trip
  end

  def new
    @trip = Trip.new
    authorize @trip
  end

  def create
    @user = current_user
    @trip = Trip.new(trip_params)
    @trip.user = @user
    authorize @trip
    if @trip.save
      if params[:trip][:photos].present?
        params[:trip][:photos].each do |photo|
          @trip.photos.attach(io: photo.tempfile, filename: photo.original_filename, content_type: photo.content_type)
        end
      end
      @participant = Participant.create!(user: @user, trip: @trip)
      redirect_to trip_path(@trip)
    else
      render "trips/index"
    end
  end

  def edit
    @trip = Trip.find(params[:id])
    authorize @trip
  end

  def update
    @trip = Trip.find(params[:id])
    authorize @trip
    @trip.update(trip_params)
    if params[:trip][:photos].present?
      params[:trip][:photos].each do |photo|
        @trip.photos.attach(io: photo.tempfile, filename: photo.original_filename, content_type: photo.content_type)
      end
    end
    redirect_to trip_path
  end

  def destroy
    @trip = Trip.find(params[:id])
    authorize @trip
    @trip.destroy
    redirect_to trips_path
  end

  private

  def trip_params
    params.require(:trip).permit(:start_date, :end_date, :title, :description, :city, :photos)
  end
end
