class User < ApplicationRecord
  include PolicyManager::Concerns::UserBehavior

end
