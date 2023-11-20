local search_ok, search = pcall(require, 'improved_search')

if not search_ok then
	return
end

local mappings = {
	n = {
		['n'] = { search.stable_next, 'stable next' },
		['N'] = { search.stable_previous, 'stable prev' },

		['!'] = { search.current_word, 'Search current word without moving.' },
	},
	x = {
		['n'] = { search.stable_next, 'stable next' },
		['N'] = { search.stable_previous, 'stable prev' },
		['!'] = { search.in_place, 'search selection without moving' },
		['*'] = { search.forward, 'search selection forward' },
		['#'] = { search.backward, 'search selection backward' },
	},
	o = {
		['n'] = { search.stable_next, 'stable next' },
		['N'] = { search.stable_previous, 'stable prev' },
		['|'] = { search.in_place, 'Search by motion in place' },
	},
}

require('core.utils').load_mappings(mappings)
