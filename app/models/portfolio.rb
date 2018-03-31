class Portfolio < ApplicationRecord
  belongs_to :user
end

#   rails g scaffold Portfolio name:string cash:decimal

