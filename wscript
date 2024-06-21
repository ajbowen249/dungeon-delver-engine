top = '.'
out = 'build'

from tools.dde_tasks import configure_dde, build_dde_game

def configure(ctx):
    configure_dde(ctx, ctx.path)

def build(bld):
    build_dde_game(bld, bld.path.find_node('src/apps/test_campaign'))
    build_dde_game(bld, bld.path.find_node('src/apps/tests'), build_co = False)
    build_dde_game(bld, bld.path.find_node('src/apps/ldhx'), build_co = False, entry_point = 0xB000)
