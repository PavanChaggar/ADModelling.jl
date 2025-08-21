module ConnectomeUtils 

using Connectomes: Connectome, Parcellation, 
                   connectome_path, node2FS, get_node_id, 
                   get_lobe, filter, laplacian_matrix, slice,
                   FS2Connectome
using DrWatson: datadir
using FileIO
dktdict = node2FS()

"""
    get_parcellation()

Return a `Connectomes.Parcellation` for the DKT atlas.
"""
function get_parcellation()
    Parcellation(connectome_path())
end

"""
   get_cortex(parc::Parcellation)

Filter the `parc` for only cortical regions.
"""
function get_cortex_parc(parc::Parcellation)
    filter(x -> get_lobe(x) != "subcortex", parc)
end

"""
   get_dkt_names(parc::Parcellation)

Generate regional names according to FreeSurfer output
"""
function get_dkt_names(parc::Parcellation)
    [dktdict[i] for i in get_node_id.(parc)]
end

function get_connectome(;include_subcortex=false, apply_filter=true, filter_cutoff=1e-2)
    c = Connectome(connectome_path())
    if include_subcortex
        if apply_filter
            fc = filter(c, filter_cutoff)
            return fc
        else
            return c
        end
    else
        cortex_parc = filter(x -> get_lobe(x) != "subcortex", c.parc)
        sc = slice(c, cortex_parc)
        if apply_filter
            fc = filter(sc, filter_cutoff)
            return fc
        else
            return sc
        end
    end 
end

_fsdict = FS2Connectome()
_getbraak(fs_regions) = [_fsdict[i] for i in fs_regions]

function get_braak_regions()
    path = pkgdir(@__MODULE__, "data")
    braak_dict = load(joinpath(path, "dicts/braak-dict.jld2"))
    ks = ["1", "2/3", "4", "5", "6"]
    fs_braak_stages = [braak_dict[k] for k in ks]    
    return map(_getbraak, fs_braak_stages)
end

end