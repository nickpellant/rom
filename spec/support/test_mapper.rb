# encoding: utf-8

class TestMapper < Struct.new(:header, :model)

  def call(relation)
    relation
  end

  def load(tuple)
    model.new(
      Hash[
        header.map { |attribute| [attribute.name, tuple[attribute.name]] }
      ]
    )
  end

  def dump(object)
    header.each_with_object([]) { |attribute, tuple|
      tuple << object.send(attribute.name)
    }
  end

end

class CityWithLocationMapper < Struct.new(:header, :model, :location_model)
  attr_reader :city_header
  attr_reader :location_header

  def initialize(header, model, location_model)
    super
    @city_header = header.project(city_header_names)
    @location_header = header.project(location_header_names)
  end

  def call(relation)
    relation
  end

  def load(tuple)
    model.new(city_attributes(tuple).merge(location: location_object(tuple[:location])))
  end

  def dump(object)
    raise NotImplementedError, "#{self.class}##{__method__} must be implemented"
  end

  private

  def city_attributes(tuple)
    Hash[city_header.map { |attribute| [attribute.name, tuple[attribute.name]] }]
  end

  def location_object(tuple)
    TestMapper.new(location_header, location_model).load(tuple)
  end

  def city_header_names
    [:id, :name]
  end

  def location_header_names
    [:lat, :lng]
  end

end

class ProjectWithTasksMapper < Struct.new(:header, :model, :task_model)
  attr_reader :task_header
  attr_reader :project_header

  def initialize(header, model, task_model)
    super
    @task_header    = header.project(task_header_names)#.rename(task_aliases)
    @project_header = header.project(project_header_names)
  end

  def call(relation)
    relation
  end

  def load(tuple)
    model.new(project_attributes(tuple).merge(tasks: task_collection(tuple)))
  end

  def dump(object)
    raise NotImplementedError, "#{self.class}##{__method__} must be implemented"
  end

  private

  def project_attributes(tuple)
    Hash[project_header.map { |attribute| [attribute.name, tuple[attribute.name]] }]
  end

  def task_collection(tuple)
    tuple[:tasks].map(&method(:task_object))
  end

  def task_object(task_tuple)
    TestMapper.new(task_header, task_model).load(task_tuple)#.rename(task_aliases))
  end

  def task_header_names
    [:task_id, :task_name]
  end

  def project_header_names
    [:id, :name]
  end
end
