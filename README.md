# ActsRateable

ActsRateable is a Rails 3 ruby gem designed to enable bi-directional polymorphic rating - users rate companies, companies rate users.  It records individual rates and caches ratings, enable quick ordering of resources by rating.

The cached ratings contain four different points of data:

		:total  => rate count
		:average => rate average
		:sum => rate sum
		:estimate => rate estimate

The estimate is probably the most useful of the data points, as it provides a weighted score based on the number of times the resource has been rated.

To determine this estimate, the gem calculates a bayesian estimate, as inspired by IMDB's top 250 list.

## Inspiration

The formula for calculating the Top Rated 250 Titles gives a true Bayesian estimate:

weighted rating (WR) = (v ÷ (v+m)) × R + (m ÷ (v+m)) × C

Where:

  R = average for the movie (mean) = (Rating)
  v = number of votes for the movie = (votes)
  m = minimum votes required to be listed in the Top 250
  C = the mean vote across the whole report (currently 7.1)

## Implementation

	* R = average rating for resource
	* v = number of ratings for resource
	* m = average number of votes
	* C = average rating of all resources

## Installation

1) Include the gem in your rails project gem file.

		gem 'acts_rateable'

2) Run:

		bundle install
		rails generate acts_rateable
		rake db:migrate

3) Add `acts_rateable` to the models you wish to have the ability to rate or be rated.

## Usage

### author.rate( resource, value )

To rate a resource:

		author.rate( resource, value )

For example,

		current_user.rate( post, 5 )

### resource.rated_by?( author )

To test whether a resource has been rated an author:

		post.rated_by?( author )

The rate will be returned if the user has rated the resource, otherwise an empty set of ratings is returned.

You may want to test it like this to get a true/false:

    post.rated_by?( author ).empty?

### author.has_rated?( resource )

To test whether an author has rated a resource:

		current_user.has_rated?( post )

The rate will be returned in the user has rated the resource, otherwise false will be returned.


### resource.rating

To get the rating for a resource:

		post.rating


### resource.rating[column]

Four types of data are cached for every resource rated:

		:total  => rate count
		:average => rate average
		:sum => rate sum
		:estimate => rate estimate

For example:

		post.rating( :total )

Will return the rate count.

		post.rating( :average )

Will return the rate average.

		post.rating( :sum )

Will return the rate sum.

		post.rating( :estimate )

Will return the rate estimate.

### resource.variation(author)

To find out how close or far off the author was in their rating from the resource estimate:

		post.variation(author)

Will return a percentage of deviation.

### order_by_rating(column, direction)

Any rateable resource may be ordered by any of the four cached data points, in either direction: DESC, ASC.

For example:

	Post.order_by_rating(:estimate, 'DESC')

Will return all posts ordered by estimate in descending order.

## Support

For issues, problems or bugs, please post an issue, here:

  https://github.com/tyrauber/acts_rateable/issues

## Future Development

For future development:

  1) fork the repository
  2) extend the functionality
  3) issue pull request
