class Train
  include Manufacturer
  include InstanceCounter
  include Validation

  attr_accessor :speed
  attr_reader :number, :type, :current_station, :wagons

  validate :number, :presence
  validate :number, :format, /^[a-z0-9]{3}-{0,1}[a-z0-9]{2}$/i
  validate :manufacturer, :presence
  validate :wagons, :each_type, Wagon

  @@trains = {}

  class << self
    def find(number)
      @@trains[number]
    end

    def all
      @@trains.values
    end
  end

  def initialize(number, manufacture_name)
    @number = number
    @manufacturer = manufacture_name
    @wagons = []
    @speed = 0
    validate!
    @@trains[number] = self
    register_instance
  end

  def stop
    @speed = 0
  end

  def length
    @wagons.length
  end

  def add_wagon(wagon)
    check_addition(wagon)
    wagon.use!(self)
    @wagons << wagon
    wagon
  end

  def remove_wagon
    @wagons.pop if @wagons.any? && @speed.zero?
  end

  def route=(route)
    @route = route
    self.station = @route.stations[0]
  end

  def go_back
    self.station = @route.stations[@index_station - 1] unless first_station?
  end

  def go_forth
    self.station = @route.stations[@index_station + 1] unless last_station?
  end

  def each_wagon
    @wagons.each { |wagon| yield(wagon) }
  end

  protected

  def check_addition(wagon)
    raise 'The train is moving !!!' if @speed != 0
    raise "This wagon is not #{@type}." if @type != wagon.type
    raise 'This wagon is not free.' unless wagon.free?
    true
  end

  def station=(station)
    @current_station.departure(self) if @current_station
    @current_station = station
    @current_station.arrival(self)
    @index_station = @route.stations.index(@current_station)
  end

  def first_station?
    @index_station.zero?
  end

  def last_station?
    @index_station == @route.stations.length - 1
  end
end
