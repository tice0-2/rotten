unless Array.method_defined? :bsearch_index
    class Array
        def bsearch_index
            return to_enum(__method__) unless block_given?
            from = 0
            to     = size - 1
            satisfied = nil
            while from <= to
                midpoint = (from + to).div(2)
                result = yield(self[midpoint])
                case result
                when Numeric
                    return midpoint if result == 0

                    result = result < 0
                when true
                    satisfied = midpoint
                when nil, false
                # nothing to do
                else
                    raise TypeError, "wrong argument type #{result.class} (must be numeric, true, false or nil)"
                end

                if result
                    to = midpoint - 1
                else
                    from = midpoint + 1
                end
            end
            satisfied
                end
            end
end

class EventQueue
    Node = Struct.new :e, :w
    # priority queue that updates time
    def initialize
        @queue = []
    end

    def add(_x, _w)
        x = Node.new _x, _w
        i = @queue.bsearch_index {|it| it.w <= x.w}
        if i.nil?
            @queue << x
        else
            @queue.insert(i, x)
        end
    end

    def pop
        x = @queue.pop
        @queue.each {|e| e.w -= x.w}
        x
    end

    def peek
        @queue.peek
    end
end

class Scheduler
    def initialize
        @queue = EventQueue.new
    end

    def <<(x)
        @queue.add x, 100.0 / x.speed
    end

    alias add <<

    def act
        e = @queue.pop
        if e.dead?
            return act
        end
        duration = e.act
        @queue.add e, 100.0 / e.speed + duration
    end
end


class DijsktraMap
    attr_reader :map, :source
    def initialize(map, source)
        @map = map
        @source = source
    end
    
    def refresh
        @data = Array.new(map.width){Array.new(map.height, Float::INFINITY)}
        @flag = Array.new(map.width){Array.new(map.height, false)}
        @data[source.x][source.y] = 0
        dijsktra(source.x, source.y)
    end

    def dijsktra(x, y)
        return if @flag[x][y]
        @flag[x][y] = true
        w = @data[x][y]
        m = neighbors(x,y).map{|it| @data[it[0]][it[1]]}.min
        if w - m > 1
            @data[x][y] = m + 1
        end
        neighbors(x,y).each do |c|
            dijsktra(*c)
        end
    end

    def neighbors(x, y)
        [[0,1],[0,-1],[1,0],[-1,0],[1,1],[1,-1],[-1,1],[-1,-1]].map do |c|
            nx = x + c[0]
            ny = y + c[1]
            [nx, ny]
        end.select do |c|
            nx, ny = *c
            @map.passable?(nx, ny)
        end
    end

    def [](x, y)
        @data[x,y]
    end

    def where_to_go x, y, desired = 0
        (neighbors(x, y) + [[x, y]]).min {|c| self[c[0]][c[1]] - desired}
    end

    def towards_where_to_go x, y, desired = 0
        c = where_to_go x, y, desired
        [c[0] - x, c[1] - y]
    end

    def show
        @data.map{|it| it * " "} * "\n" + "\n"
    end
end

Coord = Struct.new :x, :y

class DummyMap
    @@map = [
        [1, 0, 0],
        [0, 0, 0],
        [0, 0, 0],
    ]
    def width
        @@map.size
    end

    def height
        @@map[0].size
    end

    def passable? x, y
        return false unless (0...width) === x && (0...height) === y
        return @@map[x][y] == 0
    end
end