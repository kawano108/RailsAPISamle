# frozen_string_literal: true

class BooksSerializer < ActiveModel::Serializer
  attributes :id, :name, :image, :price, :purchase_date
end
