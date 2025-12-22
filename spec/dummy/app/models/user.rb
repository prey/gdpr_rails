class User < ApplicationRecord
  include PolicyManager::Concerns::UserBehavior

  def enabled_for_validation
    true
  end

  def foo_data
    30.times.map do |i|
      OpenStruct.new(
        id: i,
        country: 'Australia',
        population: 20_000_000,
        image: 'http://lorempixel.com/400/200/sports/'
      )
    end
  end

  def account_data
    {
      name: 'me',
      dob: 30.years.ago,
      image: 'https://images.pexels.com/photos/34950/pexels-photo.jpg?auto=compress&cs=tinysrgb&h=650&w=940, https://images.pexels.com/photos/34950/pexels-photo.jpg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940'
    }
  end
end
