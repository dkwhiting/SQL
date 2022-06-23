-- 1. Finding 5 oldest users
SELECT *
FROM users
ORDER BY created_at
LIMIT 5;

-- 2. Most Popular Days of Week for Registration
SELECT
	DAYNAME(created_at) AS day_of_week,
	COUNT(DAYNAME(created_at)) AS registration_count
FROM users
GROUP BY day_of_week
ORDER BY registration_count DESC;


-- 3. Identify Inactive Users (users with no photos)
SELECT 
	username as inactive_users
FROM users
LEFT JOIN photos
	ON users.id = photos.user_id
WHERE photos.user_id IS NULL;


-- 4. Identify most popular photo (and user who created it)
SELECT 
	username, 
	image_url, 
	COUNT(*) as total_likes
FROM photos
JOIN users
	ON photos.user_id = users.id
JOIN likes
	ON photos.id = likes.photo_id
GROUP BY photos.id
ORDER BY total_likes DESC
LIMIT 1;


-- 5. Calculate average number of photos per user
SELECT (SELECT COUNT(*) FROM photos)
	/ (SELECT COUNT(*) FROM users)
 	AS avg;


-- 6. Find the five most popular hashtags
SELECT 
	tag_name, 
	COUNT(*) AS total
FROM photo_tags
JOIN tags
	ON photo_tags.tag_id = tags.id
GROUP BY tags.id
ORDER BY total DESC
LIMIT 5;


-- 7. Finding the bots - the users who have liked every single photo
SELECT 
	username, 
	Count(*) AS num_likes 
FROM users 
INNER JOIN likes 
	ON users.id = likes.user_id 
GROUP  BY likes.user_id 
HAVING num_likes = (SELECT Count(*) 
                    FROM photos); 