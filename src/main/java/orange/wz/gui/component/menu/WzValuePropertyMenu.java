package orange.wz.gui.component.menu;

import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import orange.wz.gui.MainFrame;
import orange.wz.gui.component.panel.EditPane;

import javax.swing.*;

import static orange.wz.gui.Icons.AiOutlineCopy;
import static orange.wz.gui.Icons.AiOutlineDelete;

@Slf4j
public final class WzValuePropertyMenu extends JPopupMenu {
    @Getter
    private final JMenuItem deleteBtn;
    @Getter
    private final JMenuItem copyBtn;

    public WzValuePropertyMenu(EditPane editPane) {
        super();

        copyBtn = new JMenuItem(MainFrame.i18n.get("copy"), AiOutlineCopy);
        deleteBtn = new JMenuItem("删除节点", AiOutlineDelete);
        JMenuItem chineseBtn = new JMenuItem("汉化");

        copyBtn.addActionListener(e -> editPane.doCopy());
        deleteBtn.addActionListener(e -> editPane.delete());
        chineseBtn.addActionListener(e -> editPane.localizeString());

        add(copyBtn);
        add(deleteBtn);
        add(chineseBtn);
    }
}
