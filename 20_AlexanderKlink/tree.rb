class Tree
    attr_reader :children, :object

    def initialize(object)
        @object   = object
        @children = []
    end

    def add_child(child)
        if child.is_a? Tree then
            @children.push child
        else
            @children.push Tree.new(child)
        end
    end

    def contains?(object)
        # is the root itself the object we're looking for?
        contained = (@object == object)
        # iterate over the tree to look for the object
        children.each do |c|
            contained ||= c.contains? object
        end
        contained
    end

    def pp(level = 0)
        result = (" " * level) + "#{object}\n"
        @children.each do |c|
            result += c.pp(level + 1)
        end
        result
    end

    def depth(depth = 0, curr_max_depth = 0)
        if (depth > curr_max_depth)
            curr_max_depth = depth
        end
        @children.each do |c|
            curr_max_depth = c.depth(depth + 1, curr_max_depth)
        end
        curr_max_depth
    end

    # the minimal length of a path to a certain object
    def minimal_pathlength_to(object, length = 0, curr_min_length = self.depth)
        if (@object == object) && (length < curr_min_length) then
            curr_min_length = length
        end
        @children.each do |c|
            curr_min_length = c.minimal_pathlength_to(object, length + 1,
                                                      curr_min_length)
        end
        curr_min_length
    end
end
