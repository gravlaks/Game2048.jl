using Base.Threads: @threads


function move_up!(x)
    pts_scored = 0
    updated = false

    if all(==(0), x)
        return x, pts_scored, updated
    end

    # combine phase
    @inbounds for i in 1:3
        if x[i] > 0
            for j in i+1:4
                if x[j] > 0
                    if x[i] == x[j]
                        updated = true
                        x[i] += 1
                        x[j] = 0
                        pts_scored += 1 << x[i]
                    end
                    break # break out of j loop; only combine once
                end
            end
        end
    end

    # compact phase i.e. remove 0 in between
    @inbounds for i in 1:3
        while (x[i] == 0) && any(!=(0), @view x[i+1:4])
            updated = true
            x[i:3] .= @view x[i+1:4]
            x[4] = 0
        end
    end
    x, pts_scored, updated
end














function move(board, dir)
    copy_board = deepcopy(board)
    return (copy_board, move!(copy_board, dir))
end

"""make_one_move on game board"""
function move!(board, dir::Dirs)::Tuple{Int, Bool}
    return move!(board, Val(dir))
end

function move!(board, ::Val{left})
    tot_pts = 0
    any_updated = false
    for i in 1:4
        _, pts, updated = move_up!(@view board[i, :])
        tot_pts += pts
        any_updated |= updated
    end
    return (tot_pts, any_updated)
end

function move!(board, ::Val{right})
    tot_pts = 0
    any_updated = false
    for i in 1:4
        _, pts, updated = move_up!(@view board[i, 4:-1:1])
        tot_pts += pts
        any_updated |= updated
    end
    return (tot_pts, any_updated)
end

function move!(board, ::Val{up})
    tot_pts = 0
    any_updated = false
    for i in 1:4
        _, pts, updated = move_up!(@view board[:, i])
        tot_pts += pts
        any_updated |= updated
    end
    return (tot_pts, any_updated)
end

function move!(board, ::Val{down})
    tot_pts = 0
    any_updated = false
    for i in 1:4
        _, pts, updated = move_up!(@view board[4:-1:1, i])
        tot_pts += pts
        any_updated |= updated
    end
    return (tot_pts, any_updated)
end