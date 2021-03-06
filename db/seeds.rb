User.create!(name: "Example",
             email: "example@railstutorial.org",
             password: "foobar",
             password_confirmation: "foobar",
             admin: true,
             activated: true,
             activated_at: Time.zone.now)

99.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "123456"
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now)
end

user = User.order(:created_at).take(6)
50.times do
  content = Faker::Lorem.sentence(5)
  user.each do |user|
    user.microposts.create(content: content)
  end
end
