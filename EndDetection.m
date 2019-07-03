function [v_num]=EndDetection(x)
 %================================i=========================
 % 端点检测
 % Input:音频数据x,采样率fs
 % Output：经过端点检测提取的语音信号
 %=========================================================

%幅度归一化到[-1,1]
x = double(x);
x = x / max(abs(x));

%常数设置
FrameLen = 256;%帧长为256点
FrameInc = 80;%帧移为80点
amp1 = 10;%初始短时能量高门限
amp2 = 0.6;%初始短时能量低门限
zcr1 = 10;%初始短时过零率高门限
zcr2 = 5;%初始短时过零率低门限
maxsilence = 8;  % 8*10ms  = 80ms

%语音段中允许的最大静音长度，如果语音段中的静音帧数未超过此值，则认为语音还没结束；如果超过了
%该值，则对语音段长度count进行判断，若count<minlen，则认为前面的语音段为噪音，舍弃，跳到静音
%状态0；若count>minlen，则认为语音段结束；

minlen  = 60;    % 60*10ms = 600ms
%语音段的最短长度，若语音段长度小于此值，则认为其为一段噪音

status  = 0;     %初始状态为静音状态
count   = 0;     %初始语音段长度为0
silence = 0;     %初始静音段长度为0

%计算过零率
x1 = x(1:end-1);
x2 = x(2:end);
%分帧
tmp1 = enframe(x1,FrameLen,FrameInc);
tmp2 = enframe(x2,FrameLen,FrameInc);
signs = (tmp1.*tmp2)<0;
diffs = (tmp1 -tmp2)>0.02;
zcr = sum(signs.*diffs, 2);%一帧一个值

%计算短时能量
amp = sum(abs(enframe(x, FrameLen, FrameInc)), 2);

%调整能量门限
amp1 = min(amp1, max(amp)/4);
amp2 = min(amp2, max(amp)/8);

%开始端点检测
%For循环，整个信号各帧比较
%根据各帧能量判断帧所处的阶段
x1 = 0;
x2 = 0;
v_num=0;%记录语音段数
v_Begin=[];%记录所有语音段的起点
v_End=[];%记录所有语音段的终点

%length(zcr)即为帧数
for n=1:length(zcr)
   goto = 0;
   switch status
   case {0,1}                   % 0 = 静音, 1 = 可能开始
      if amp(n) > amp1          % 确信进入语音段
         x1 = max(n-count-1,1);
%          '打印每个x1*FrameInc'
%          x1*FrameInc
         status  = 2;
         silence = 0;
         count   = count + 1;
      elseif amp(n) > amp2 || ... % 可能处于语音段
             zcr(n) > zcr2
         status = 1;
         count  = count + 1;
      else                       % 静音状态
         status  = 0;
         count   = 0;
      end
   case 2                     % 2 = 语音段
      if amp(n) > amp2 ||...     % 保持在语音段
         zcr(n) > zcr2
         count = count + 1;
      else                       % 语音将结束
         silence = silence+1;
         if silence < maxsilence % 静音还不够长，尚未结束
            count  = count + 1;
         elseif count < minlen   % 语音长度太短，认为是噪声
            status  = 0;
            silence = 0;
            count   = 0;
         else                    % 语音结束
            status  = 3;
         end
      end
   case 3
      %break;
      %记录当前语音段数据
      v_num=v_num+1;   %语音段个数加一
      count = count-silence/2;
      x2 = x1 + count -1;
      v_Begin(1,v_num)=x1*FrameInc; 
      v_End(1,v_num)=x2*FrameInc;
      %不跳出 数据归零继续往下查找下一段语音
      status  = 0;     %初始状态为静音状态
      count   = 0;     %初始语音段长度为0
      silence = 0;     %初始静音段长度为0


   end
end  
% 
% if length(v_End)==0
%     x2 = x1 + count -1;
%     v_Begin(1,1)=x1*FrameInc; 
%     v_End(1,1)=x2*FrameInc;
% end
% figure(1)
% plot(x)
% axis([1 length(x) -1 1])
% ylabel('Speech');
% for k=1:length(v_End)
% line([v_Begin(1,k) v_Begin(1,k)], [-1 1], 'Color', 'g');
% %这里作用为用直线画出语音段的起点和终点，看起来更直观。第一个[]中的两个参数为线起止点的横坐标，
% 
% %第二个[]中的两个参数为线起止点的纵坐标。最后两个参数设置了线的颜色。
% line([v_End(1,k) v_End(1,k)], [-1 1], 'Color', 'red');
% end