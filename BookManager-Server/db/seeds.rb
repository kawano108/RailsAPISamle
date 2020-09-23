require 'faker'

Book.skip_callback(:save, :before, :convert_image)

10.times do |n|
    user = User.create(email: Faker::Internet.email, password: Faker::Internet.password)
    rand(20).times do |n|
        book = user.books.build(name: Faker::Book.title,
            image: 'https://i.imgur.com/tdWnPfG.png',
            price: Faker::Number.number(digits: 4),
            purchase_date: Faker::Date.backward.to_s)
        book.save 
    end
end
