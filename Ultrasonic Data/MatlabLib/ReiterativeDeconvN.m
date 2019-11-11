function  [LayersAmp, LayersToF, ArrayToStrip] = ReiterativeDeconvN(ArrayToStrip,Ref,N, DoXcorrInMatlab);
%function  [LayersAmp, LayersL2N,LayersToF, ArrayToStrip] = ReiterativeDeconvN(ArrayToStrip,Ref,N, DoXcorrInMatlab);
%used to strip Ref from ArrayToStrip by REiterative deconvolution
%amplitude and ToF of every iteration are estimated by Xcorr with Ref,
%ToF subsample estimate using COSINE interpolation
%data in ArrayToStrip is (NrOfXst,AscanLength) size (1D array of A-scans)
% DoXcorrInMatlab - defines processing type:
% 1 - use matlab xcorr function (using FFT?);
% 2 - xcorr in time domain (see help XcoorInTime);
%returns:
%residual, stripped array (ArrayToStrip)
%LayersAmp(LayerNo,xnr) - amplitude of every iteration of ToF estimation,
%LayersL2N(LayerNo,xnr)  - L2 norm of the residual signal
%LayersToF(LayerNo,xnr)-  ToF of every iteration;
%can use two neigboring ToF values (e.g. LayersToF(2,xnr)-LayersToF(1,xnr))
%to get delta ToF.
if exist('DoXcorrInMatlab')==0, DoXcorrInMatlab=1, end;
[NrOfXst,AscanLength]=size(ArrayToStrip);
ArrayToStrip0=ArrayToStrip;
stripIterNo=50; % 20 for real experiment; 100 for analysis
RAmp=sum(Ref.^2)/length(Ref);



for xnr=1:NrOfXst,
    for LayerNo=1:stripIterNo,
        if LayerNo==1,
            for SNr=1:N
                % % First iteration....
                TOF=GetTOFcos(ArrayToStrip(xnr,:),Ref);
                currentToF(SNr)=TOF; %-AscanLength
                RefShifted=shiftSubsampleByfft(Ref,-currentToF(SNr));
                Amp(SNr)=sum(ArrayToStrip(xnr,:).*RefShifted)/length(RefShifted)/RAmp;
                
                ArrayToStrip(xnr,:)=ArrayToStrip(xnr,:)-RefShifted*Amp(SNr);
                
                LayersToF(LayerNo,xnr,SNr)=currentToF(SNr);
                LayersAmp(LayerNo,xnr,SNr)=Amp(SNr);

                %         LayersL2N(LayerNo,xnr)=sum((ArrayToStrip(xnr,:)).^2);
                % % Reuse primary signal without previuos ToF
            end;
%             SortMatrixT=LayersToF(LayerNo,xnr,:);
%             SortMatrixA=LayersAmp(LayerNo,xnr,:)
%             for Snr=2:N
%                 if SortMatrixT(Snr-1)<SortMatrixT(Snr)
%                    SortMatrixT(Snr-1)= LayersToF(LayerNo,xnr,SNr);
%                    SortMatrixT(Snr)=LayersToF(LayerNo,xnr,SNr-1);
%                    SortMatrixA(Snr-1)= LayersAmp(LayerNo,xnr,SNr);
%                    SortMatrixA(Snr)=LayersAmp(LayerNo,xnr,SNr-1);
%                 end
%             end
%             LayersToF(LayerNo,xnr,:)=SortMatrixT;
%             LayersAmp(LayerNo,xnr,:)=SortMatrixA;
        end;
        if LayerNo>1,
            %   Next iteration
            for ii=1:N
                ArrayToStrip0N(xnr,:,ii)=ArrayToStrip0(xnr,:);
                ArrayToStripPR(xnr,:,ii)=ArrayToStrip0N(xnr,:,ii);
                
                for jj=1:N
                    if jj~=ii
                        RefShifted1(jj,:)=shiftSubsampleByfft(Ref,-currentToF(jj));
                        ArrayToStrip0N(xnr,:,ii)=ArrayToStrip0N(xnr,:,ii)-RefShifted1(jj,:)*Amp(jj);
%                         figure(9)
%                         plot(RefShifted1(jj,:)*Amp(jj), 'g');
%                         hold on
                    end;
                end;
                TOF=GetTOFcos(ArrayToStrip0N(xnr,:,ii),Ref);
                currentToF(ii)=TOF; %-AscanLength
                RefShifted=shiftSubsampleByfft(Ref,-currentToF(ii));
                Amp(ii)=sum(ArrayToStrip0N(xnr,:,ii).*RefShifted)/length(RefShifted)/RAmp;
                LayersToF(LayerNo,xnr,ii)=currentToF(ii);
                LayersAmp(LayerNo,xnr,ii)=Amp(ii);
                                
%                 plot(ArrayToStripPR(xnr,:,ii),'-ok')
%                 plot(ArrayToStrip0N(xnr,:,ii), 'r')
%                 plot(ArrayToStrip0(xnr,:), 'b')
%                 pause
%                 hold off
            end;
%             SortMatrixT=LayersToF(LayerNo,xnr,:);
%             SortMatrixA=LayersAmp(LayerNo,xnr,:)
%             for Snr=2:N
%                 if SortMatrixT(Snr-1)<SortMatrixT(Snr)
%                    SortMatrixT(Snr-1)= LayersToF(LayerNo,xnr,SNr);
%                    SortMatrixT(Snr)=LayersToF(LayerNo,xnr,SNr-1);
%                    SortMatrixA(Snr-1)= LayersAmp(LayerNo,xnr,SNr);
%                    SortMatrixA(Snr)=LayersAmp(LayerNo,xnr,SNr-1);
%                 end
%             end
%             LayersToF(LayerNo,xnr,:)=SortMatrixT;
%             LayersAmp(LayerNo,xnr,:)=SortMatrixA;
        end
    end
end;
%sort iterations
% for xnr=1:NrOfXst,
%     for LayerNo=1:stripIterNo,
%         iToF=squeeze(LayersToF(LayerNo,xnr,:));
%         iA=squeeze(LayersAmp(LayerNo,xnr,:));
%         [YY,II]=sort(iToF);
%         LayersToF(LayerNo,xnr,:)=YY;
%         LayersAmp(LayerNo,xnr,:)=iA(II);
%     end;
% end;
