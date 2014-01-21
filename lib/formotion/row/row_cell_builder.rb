#################
#
# Formotion::RowCellBuilder
# RowCellBuilder handles taking Formotion::Rows
# and configuring UITableViewCells based on their properties.
#
#################
module Formotion
  class RowCellBuilder
    extend BW::KVO

    # PARAMS row.is_a? Formotion::Row
    # RETURNS [cell configured to that row, a UITextField for that row if applicable or nil]
    def self.make_cell(row)
      cell, text_field = nil

      cell = UITableViewCell.alloc.initWithStyle(row.object.cell_style, reuseIdentifier:row.reuse_identifier)

      cell.accessoryType = cell.editingAccessoryType = UITableViewCellAccessoryNone

      cell.textLabel.text = row.title
      observe(row, "title") do |old_value, new_value|
        cell.textLabel.text = new_value
      end

      if row.image
        Formotion::RowCellBuilder.set_image(cell, row)
        observe(row, "image") do |old_value, new_value|
          Formotion::RowCellBuilder.set_image(cell, row)
        end
      end

      cell.detailTextLabel.text = row.subtitle
      observe(row, "subtitle") do |old_value, new_value|
        cell.detailTextLabel.text = new_value
      end

      edit_field = row.object.build_cell(cell)

      if edit_field and edit_field.respond_to?("accessibilityLabel=")
        label = row.accessibility
        label = row.title unless label
        edit_field.accessibilityLabel = label if label
      end

      [cell, edit_field]
    end

    def self.set_image(cell, row)
      if row.image.is_a?(NSURL) || (row.image.is_a?(String) && row.image.include?("http"))
        # Use a remote image helper to set the image.
        image_url = row.image
        image_url = NSURL.URLWithString(image_url) unless image_url.is_a?(NSURL)

        placeholder = row.image_placeholder
        placeholder = UIImage.imageNamed(placeholder) if placeholder.is_a?(String)

        if cell.imageView.respond_to?("setImageWithURL:placeholderImage:")
          # Use AFNetworking / AFMotion
          cell.imageView.setImageWithURL(image_url, placeholderImage: placeholder)
        elsif cell.imageView.respond_to?("setImageWithURL:placeholder:")
          # Use JMImageCache
          cell.imageView.setImageWithURL(image_url, placeholder: placeholder)
        else
          raise "Please add the afmotion gem of the JMImageCache cocoapod to your project to use remote images in formotion"
        end

      else
        # Just set the image like normal
        cell.imageView.image = (row.image.is_a? String) ? UIImage.imageNamed(row.image) : row.image
      end
    end

  end
end
