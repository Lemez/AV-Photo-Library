# Run with "ruby script.rb"

require "google_drive"
require 'json'

IMG_DB_ID = "0B9Zii-t9akm4Q2U4SXhCSGtMN2M"

def send_data(params)
	p "sending data >> Ruby"

	title = params["metadata"]
	file = params["file"]["tempfile"]

	p "Title: #{title} for #{file}"

	p file.inspect

	upload_to_drive(file.path, title)
end

def add_open_permissions
	$session.files.first.acl.push({
		type: "anyone", allow_file_discovery: false, role: "reader"})
end


def process_form(data)
	puts data
end

def init_session
	$session = GoogleDrive::Session.from_config("client.json")
	$mymethods = [:parents,:size, :name, :version, :description, :original_filename, :id, :mime_type,  :spaces, :kind, :created_time, :modified_time, :app_properties, :capabilities, :content_hints, :file_extension, :folder_color_rgb, :full_file_extension, :has_thumbnail, :has_thumbnail?, :head_revision_id, :icon_link, :image_media_metadata, :last_modifying_user,  :permissions, :properties, :thumbnail_link, :thumbnail_version, :web_content_link, :web_view_link, :inspect, :title]
	$img_methods = [:time, :width, :aperture, :camera_make, :camera_model, :color_space, :exposure_bias, :exposure_mode, :exposure_time, :flash_used, :flash_used?, :focal_length, :height, :iso_speed, :lens, :location, :max_aperture_value, :metering_mode, :rotation, :sensor, :subject_distance, :white_balance]
	$title_json_fields = [:category, :tags, :description, :type, :country, :state, :place, :author, :name, :mimetype]
end

def all_data
	init_session
	db_files = $session.files.select{|f|!f.parents.nil? && f.parents.include?(IMG_DB_ID)}
	db_files.each{|f| $mymethods.each{|m| 
		begin
			puts "#{m}: #{f.send(m)}"
		rescue => e
			puts "#{m}: #{e}"
		end
		}
		p "********"
	}
	p "____________________________"
end

def init_metadata
	{		:size=>0,
			:width=>'', 
			:height=>'', 
			:aspect=>'', 
			:aspect_ratio=>'', 
			:drive_id=>'',
			:created_at=>'', 
			:modified_at=>'',
			:shot=>'', 
			:thumb_url=>'', 
			:url=>'', 
			:preview=>''}

end

def add_descriptive_metadata_to(data,title)
	jsonstring = JSON.parse(title)

	$title_json_fields.each do |sym|
		begin
			data[sym]=jsonstring[sym.to_s]
			if data[sym][0]=="["
				data[sym]=data[sym].to_a
			end
		rescue
			data[sym]=''
		end
	end

	data
end

def add_technical_metadata_to(data,f)
		data[:width] = f.send(:image_media_metadata).width.to_f
		data[:height] = f.send(:image_media_metadata).height.to_f

		aspect = (data[:width]/data[:height]).round(2)
		aspect_ratio = 'other'

		case aspect
		when 1.78
			aspect_ratio = "16x9"
		when 1.33
			aspect_ratio = "4x3"
		end 

		data[:aspect] = aspect
		data[:aspect_ratio]=aspect_ratio
		data[:size] = f.size

		data[:shot] = f.send(:image_media_metadata).time
		data[:created_at]=f.created_time 
		data[:modified_at]=f.modified_time
		data[:extension]=f.full_file_extension 
		data[:thumb_url]=f.thumbnail_link 
		data[:url]=f.web_content_link
		data[:preview]=f.web_view_link

		data[:original_name]=f.original_filename
		data[:drive_id]=f.id

end


def get_data
	puts "getting data"
	init_session
	all_images = $session.files.select{|f|["JPG","jpg","jpeg","JPEG","gif","png","PNG","GIF","tiff","tif","TIFF","TIF","bmp","BMP"].include?(f.file_extension)}

	db_files = $session.files.select{|f|!f.parents.nil? && f.parents.include?(IMG_DB_ID)}

	@data_array = []

	db_files.each do |file|
		# status = (f.explicitly_trashed? ? "Dead" : "Alive")
		next if file.explicitly_trashed?

		@object = init_metadata

		add_technical_metadata_to(@object,file)
		@object = add_descriptive_metadata_to(@object,file.title)

		@data_array << @object

		@object.each{|k,v| p "#{k}: #{v}"}
		p "--------"
		
	end

	@data_array

end

def save_file_as_json(data)
	File.open('test.json','w') do |f|
	f.puts(data.to_json)
	end
end


