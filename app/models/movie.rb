class Movie < ActiveRecord::Base
  belongs_to :genre
  belongs_to :studio
  has_and_belongs_to_many :actors
  has_and_belongs_to_many :writers

  def self.import
    Rails.logger.info "Cleaning up.."

    Movie.delete_all
    Genre.delete_all
    Studio.delete_all

    actors = []
    142.times do
      actors << Actor.create(name: Faker::Name.name)
    end

    writers = []
    123.times do
      writers << Writer.create(name: Faker::Name.name)
    end

    Rails.logger.info "parsing data.."
    f = File.join(Rails.root, 'movies.yml')
    movies = YAML.load_file(f)
    genres_m = movies.group_by {|m| m[:genre]}
    studios_m = movies.group_by {|m| m[:studio]}

    genres = {}
    studios = {}

    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

    Rails.logger.info "Creating Genres.."
    genres_m.keys.each {|g| genres[g] = Genre.create(name: g);}
    Rails.logger.info "Creating Studios.."
    studios_m.keys.each {|s| studios[s] = Studio.create(name: s)}

    total = movies.length
    Rails.logger.info "Creating Movies: #{total} movies total."
    r = Random.new
    movies.take(9000).each_with_index do |m,i|
      Movie.create(
        title: m[:title],
        year: m[:year],
        studio: studios[m[:studio]],
        genre: genres[m[:genre]],
        price: r.rand(100),
        actors: (1..(rand(7)+1)).to_a.map {actors[rand(actors.length)]}.uniq,
        writers: (1..rand(3)).to_a.map {writers[rand(writers.length)]}.uniq
      )

    end
    ActiveRecord::Base.logger = old_logger
  end
end
