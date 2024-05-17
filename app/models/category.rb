# frozen_string_literal: true

class Category < ApplicationRecord
  # Default scope to order categories alphabetically by name
  default_scope { order(:name) }

  # Scope to get all categories that are considered verticals (no parent)
  scope :verticals, -> { where(parent_id: nil) }

  # Association indicating the parent category, which is optional
  belongs_to :parent, class_name: "Category", optional: true

  # Association for child categories
  has_many :children, class_name: "Category", inverse_of: :parent
  # Association for category attributes with dependency on category's existence
  has_many :categories_attributes,
    dependent: :destroy,
    foreign_key: :category_id,
    primary_key: :id,
    inverse_of: :category
  # Through association to access related attributes directly from category
  has_many :related_attributes, through: :categories_attributes

  # Validation to ensure presence and specific format of category ID
  validates :id,
    presence: { strict: true },
    format: { with: /\A[a-z]{2}(-\d+)*\z/ }
  # Validation to ensure presence of category name
  validates :name,
    presence: { strict: true }
  # Custom validation to check if ID matches the expected depth
  validate :id_matches_depth
  # Custom validation to ensure ID starts with parent ID, unless it's a root category
  validate :id_starts_with_parent_id,
    unless: :root?
  # Validation to ensure all associated children are valid
  validates_associated :children


  class << self
    # Method to generate a global ID for a category
    def gid(id)
      "gid://open-taxonomy/TaxonomyCategory/#{id}"
    end

    # Methods for data deserialization

    # Create a new category instance from data hash
    def new_from_data(data)
      new(row_from_data(data))
    end

    # Bulk insert categories from an array of data hashes
    def insert_all_from_data(data, ...)
      insert_all(Array(data).map { row_from_data(_1) }, ...)
    end

    # Methods for dist serialization

    # Convert a collection of verticals to JSON format with versioning
    def as_json(verticals, version:)
      {
        "version" => version,
        "verticals" => verticals.map(&:as_json_with_descendants),
      }
    end

    # Convert a collection of verticals to a formatted text string
    def as_txt(verticals, version:)
      header = <<~HEADER
        # Open Product Taxonomy - Categories: #{version}
        # Format: {GID} : {Ancestor name} > ... > {Category name}
      HEADER
      padding = reorder("LENGTH(id) desc").first.gid.size
      [
        header,
        *verticals.flat_map(&:descendants_and_self).map { _1.as_txt(padding:) },
      ].join("\n")
    end

    # Methods for docs parsing

    # Generate JSON structure for documentation, grouping siblings by level and parent
    def as_json_for_docs_siblings(distribution_verticals)
      distribution_verticals.each_with_object({}) do |vertical, groups|
        vertical["categories"].each do |data|
          parent_id = data["parent_id"].presence || "root"
          sibling = {
            "id" => data["id"],
            "name" => data["name"],
            "description" => data["description"] || "",
            "fully_qualified_type" => data["full_name"],
            "depth" => data["level"],
            "parent_id" => parent_id,
            "node_type" => data["level"].zero? ? "root" : "leaf",
            "ancestor_ids" => data["ancestors"].map { _1["id"] }.join(","),
            "attribute_ids" => data["attributes"].map { _1["id"] }.join(","),
          }

          groups[data["level"]] ||= {}
          groups[data["level"]][parent_id] ||= []
          groups[data["level"]][parent_id] << sibling
        end
      end
    end

    # Generate JSON for search functionality in documentation
    def as_json_for_docs_search(distribution_verticals)
      distribution_verticals.flat_map do |vertical|
        vertical["categories"].map do |data|
          {
            "title" => data["full_name"],
            "url" => "?categoryId=#{CGI.escapeURIComponent(data["id"])}",
            "category" => {
              "id" => data["id"],
              "name" => data["name"],
              "fully_qualified_type" => data["full_name"],
              "depth" => data["level"],
              "description" => data["description"] || "", # Include description in JSON
            },
          }
        end
      end
    end

    private

    # Helper method to extract row data from a data hash
    def row_from_data(data)
      {
        "id" => data["id"],
        "parent_id" => parent_id_of(data["id"]),
        "name" => data["name"],
        "description" => data["description"] || "", # Include description in row data
      }
    end

    # Helper method to determine parent ID from a given ID
    def parent_id_of(id)
      id.split("-")[0...-1].join("-").presence
    end
  end

  # Instance method to get the global ID
  def gid
    self.class.gid(id)
  end

  # Method to get the full name of the category, including all ancestors
  def full_name
    ancestors.reverse.map(&:name).push(name).join(" > ")
  end

  # Check if the category is a root category
  def root?
    parent.nil?
  end

  # Check if the category is a leaf category (no children)
  def leaf?
    children.empty?
  end

  # Get the depth level of the category based on its ancestors
  def level
    ancestors.size
  end

  # Get the root category of the current category
  def root
    ancestors.last || self
  end

  # Get all ancestors of the category
  def ancestors
    if root?
      []
    else
      [parent] + parent.ancestors
    end
  end

  # Get all ancestors and include self in the list
  def ancestors_and_self
    [self] + ancestors
  end

  # Get all descendants of the category in a depth-first manner
  def descendants
    children.flat_map { |child| [child] + child.descendants }
  end

  # Get all descendants and include self in the list
  def descendants_and_self
    [self] + descendants
  end

  # Setter method to assign related attributes by their friendly IDs
  def related_attribute_friendly_ids=(ids)
    self.related_attributes = Attribute.where(friendly_id: ids)
  end

  # Methods for data serialization

  # Convert category to JSON format for data purposes
  def as_json_for_data
    {
      "id" => id,
      "name" => name,
      "description" => description,
      "children" => children.map(&:id),
      "attributes" => related_attributes.reorder(:id).map(&:friendly_id),
    }
  end

  # Convert category and its descendants to JSON format for distribution purposes
  def as_json_with_descendants
    {
      "name" => name,
      "description" => description || "",
      "prefix" => id.downcase,
      "categories" => descendants_and_self.map(&:as_json),
    }
  end

  # Convert category to JSON format
  def as_json
    {
      "id" => gid,
      "level" => level,
      "name" => name,
      "full_name" => full_name,
      "description" => description || "",
      "parent_id" => parent&.gid,
      "attributes" => related_attributes.map do
        {
          "id" => _1.gid,
          "name" => _1.name,
          "handle" => _1.handle,
          "extended" => _1.extended?,
        }
      end,
      "children" => children.map do
        {
          "id" => _1.gid,
          "name" => _1.name,
        }
      end,
      "ancestors" => ancestors.map do
        {
          "id" => _1.gid,
          "name" => _1.name,
        }
      end,
    }
  end

  # Convert category to a formatted text string
  def as_txt(padding: 0)
    "#{gid.ljust(padding)} : #{full_name}"
  end

  private

  # Custom validation to ensure the ID has the correct number of parts
  def id_matches_depth
    return if id.count("-") == level

    errors.add(:id, "#{id} must have #{level + 1} parts")
  end

  # Custom validation to ensure the ID starts with the parent's ID
  def id_starts_with_parent_id
    return if id.start_with?(parent.id)

    errors.add(:id, "#{id} must be prefixed by parent_id=#{parent_id}")
  end
end
