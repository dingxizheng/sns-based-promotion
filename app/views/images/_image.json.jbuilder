
json.url image_url( image )
json.id image.get_id
json.extract! image, :file_name, :extension, :size, :height, :width, :image_url, :thumb_url, :medium_url