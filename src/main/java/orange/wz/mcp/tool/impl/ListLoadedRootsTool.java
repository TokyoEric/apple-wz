package orange.wz.mcp.tool.impl;

import orange.wz.mcp.service.McpWorkspaceService;
import orange.wz.mcp.session.McpSessionManager;
import orange.wz.mcp.tool.support.BaseSessionTool;

import java.util.Map;

public final class ListLoadedRootsTool extends BaseSessionTool {
    private final McpWorkspaceService service;

    public ListLoadedRootsTool(McpSessionManager sessionManager, McpWorkspaceService service) {
        super(sessionManager);
        this.service = service;
    }

    @Override
    public String name() {
        return "list_loaded_roots";
    }

    @Override
    public Map<String, Object> invoke(Map<String, Object> params) {
        var session = session(params);
        var roots = service.listLoadedRoots(session);
        return Map.of("roots", roots, "rootCount", roots.size());
    }
}
