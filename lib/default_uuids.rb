# This file contains all of the default UUID-to-constant mappings
# that should be present in every instance of the Services
# plugin. If you have UUIDs you wish to add for your application,
# please use local_uuids.rb.

module ServicesModule
	module DefaultUUIDs
		# Constants for data types

		DTYPE_POST			= "13569fca-5b8c-4ec3-8738-350165a37592" # A blog post.
		DTYPE_EVENT			= "1a5527bb-515b-4f69-807e-facf578e0f2d" # A calendar event.
		DTYPE_COMMENT		= "9a232c1d-55f7-4edd-8b60-e942eca82ea2" # A blog post comment.
		DTYPE_PROFILE_FIELD	= "065479a8-d2da-4e39-881a-ada619b1a252" # A profile field

		# Constants for data groups

		DGROUP_BLOG			= "f7ae8ebd-c49a-4c9c-8f8c-425d32e64d88" # A user/group/site's blog.
		DGROUP_CALENDAR		= "ae32a6aa-bfb2-4126-87a1-7041da0ce6e5" # A calendar.
		DGROUP_COMMENTS		= "841d7152-1a50-43c5-b53f-75437faad6a2" # A blog post's comments.
		DGROUP_PROFILE		= "bf1d3af2-3437-489f-9f09-24151edeb827" # A user/group's profile

		# Default creator/owner constants
		NOBODY				= "574ecd0f-afb1-40e4-a71b-1e66622db0de"
		ANONYMOUS			= "00000000-0000-0000-0000-000000000000"
		
		# Constants for storages
		STYPE_FOLDER		= "438754d6-227b-4a06-9400-79e941d2fd45" # A folder
		STYPE_FILE			= "00000000-227b-4a06-9400-79e941d2fd45" # A file

        # Constants for subscriptions
        ONLINE_SUB			= "8c730f9c-a95a-41e7-bd38-ada9277dc6ab" # Online subscription (for something online)
        OFFLINE_SUB			= "21a2ed06-f315-4941-9af8-a678dbed8858" # Offline subscription (for something offline)
        WIDGET_SUB			= "666ce30b-2a44-469b-ab29-42a65bfcc337" # Widget subscription
        ONETIME_PAYMENT		= "6ea5818d-dbdf-4d96-95f7-f52a36234ecc" # One-time payment

        # Constants for ForumService
        FORUM_BOARD         = "7cc68ffa-56c4-4c6e-b5ab-4319418e0856"
        FORUM_CATEGORY      = "ed194950-ee23-4e0a-aea3-6bbdb80eb23c"
        FORUM               = "1c1723c3-715b-45c2-bdea-d550493d80e5"
        FORUM_POST_GROUP    = "5e9fbdf5-36d9-4eb3-86bf-577da5b9c28e"          
        FORUM_POST          = "00000000-36d9-4eb3-86bf-577da5b9c28e"
        FORUM_REPLY         = "00000000-8f92-4d87-8039-d4a04a05f65d"        
	end
end
