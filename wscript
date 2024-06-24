top = '.'
out = 'build'

from tools.dde_tasks import dde_options, configure_dde, build_dde_game, PLATFORM_TRS80_M100

def options(ctx):
    dde_options(ctx)

def configure(ctx):
    configure_dde(ctx, ctx.path)

def build(bld):
    build_dde_game(bld, bld.path.find_node('src/apps/test_campaign'), is_dde_inner = True)
    build_dde_game(
        bld,
        bld.path.find_node('src/apps/tests'),
        build_m100_co = False,
        build_hex = False,
        build_zx_tap = False,
        is_dde_inner = True,
    )

    build_dde_game(
        bld,
        bld.path.find_node('src/apps/ldhx'),
        build_m100_co = False,
        entry_point_trs80_m100 = 0xB000,
        platforms = [ PLATFORM_TRS80_M100 ],
        is_dde_inner = True,
    )
