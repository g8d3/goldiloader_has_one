begin
	require 'bundler/inline'
rescue LoadError => e
	$stderr.puts 'Bundler version 1.10 or later is required. Please update your Bundler'
	raise e
end

gemfile(true) do
	source 'https://rubygems.org'
	# Activate the gem you are reporting the issue against.
	gem 'activerecord', '4.2.0'
	gem 'sqlite3'
	gem 'goldiloader'
	gem 'pry'
end

require 'active_record'
require 'minitest/autorun'
require 'logger'

# Ensure backward compatibility with Minitest 4
Minitest::Test = MiniTest::Unit::TestCase unless defined?(Minitest::Test)

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
	create_table :posts, force: true do |t|

	end

	create_table :things, force: true do |t|
		t.integer :post_id
	end

	create_table :comments, force: true do |t|
		t.integer :post_id
	end
end

class Post < ActiveRecord::Base
	has_many :comments
	has_one :thing
end

class Comment < ActiveRecord::Base
	belongs_to :post
	has_one :thing, through: :post
end

class Thing < ActiveRecord::Base
	belongs_to :post
	has_many :comments, through: :post
end

class BugTest < Minitest::Test
	def test_association_stuff
		post = Post.create!
		post1 = Post.create!
		post.comments << Comment.create!
		post.comments << Comment.create!
		post1.comments << Comment.create!
		Post.all.each do |post|
			Thing.create post: post
		end
		binding.pry


		# assert_equal 2, post.comments.count
		# assert_equal 3, Comment.count
		# assert_equal post.id, Comment.first.post.id



		Comment.all.each do |c|
			p c.post.id
			p c.thing.id
		end

		# Post.all.each do |post|
		# 	post.comments.each do |c|
		# 		p c.id
		# 	end
		# 	post.thing.id
		# end
	end
end
