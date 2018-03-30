class Portfolio < ApplicationRecord
  belongs_to :user
end

#   rails g scaffold Portfolio user:references name:string cash:decimal

