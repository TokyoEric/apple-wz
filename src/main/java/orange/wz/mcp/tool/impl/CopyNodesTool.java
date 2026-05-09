package orange.wz.mcp.tool.impl;

import orange.wz.mcp.service.McpWorkspaceService;
import orange.wz.mcp.session.McpSessionManager;
import orange.wz.mcp.tool.support.BaseSessionTool;
import orange.wz.mcp.tool.support.ToolParamHelper;

import java.util.Map;

public final class CopyNodesTool extends BaseSessionTool {
    private final McpWorkspaceService service;

    public CopyNodesTool(McpSessionManager sessionManager, McpWorkspaceService service) {
        super(sessionManager);
        this.service = service;
    }

    @Override
    public String name() {
        return "copy_nodes";
    }

    @Override
    public Map<String, Object> invoke(Map<String, Object> params) {
        var session = session(params);
        var sources = ToolParamHelper.getNodeReferenceList(params, "sources");
        boolean autoParse = ToolParamHelper.getBoolean(params, "autoParse", true);
        service.copyNodes(session, sources, autoParse);
        return Map.of("copiedCount", sources.size());
    }
}
