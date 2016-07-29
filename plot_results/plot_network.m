hold on
for i=1:7
    plot(eNodeBs(i).pos(1),eNodeBs(i).pos(2),'x');
    text(eNodeBs(i).pos(1),eNodeBs(i).pos(2),int2str(i));
end